import { Request, Response } from "express";
import errors from "../constants/errors";
import { getUserByField, getUsersByField } from "../db/auth.db";
import IResp from "../types/IResp.interface";
import IUser from "../types/IUser.interface";

class NotificationController {
  private getUsersInWaitingRoom = async (): Promise<IUser[]> => {
    const usersInWaitingRoom: IUser[] | null = await getUsersByField(
      "registration_status",
      "under review"
    );
    return usersInWaitingRoom || [];
  };

  private getAdminNotifications = async (): Promise<{
    usersInWaitingRoom: IUser[];
  }> => {
    const usersInWaitingRoom = await this.getUsersInWaitingRoom();
    return { usersInWaitingRoom };
  };

  private getAdminNotificationsCount = async (): Promise<number> => {
    const adminNotifications = await this.getAdminNotifications();
    const count: number = adminNotifications.usersInWaitingRoom?.length + 0;
    return count;
  };

  private getArchiveNotifications = async (): Promise<{}> => {
    return {};
  };

  private getArchiveNotificationsCount = async (): Promise<number> => {
    const archiveNotifications = await this.getArchiveNotifications();
    const count: number = 0;
    return count;
  };

  private getSettingsNotifications = async (): Promise<{}> => {
    return {};
  };

  private getSettingsNotificationsCount = async (): Promise<number> => {
    const settingsNotifications = await this.getAdminNotifications();
    const count: number = 0;
    return count;
  };

  public adminGetAllCount = async (
    req: Request,
    res: Response<IResp<number>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const adminNotificationsCount = await this.getAdminNotificationsCount();

      res.status(200).json({
        status: true,
        data: adminNotificationsCount,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public adminGetAll = async (
    req: Request,
    res: Response<IResp<{ usersInWaitingRoom: IUser[] }>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const adminNotifications = await this.getAdminNotifications();

      res.status(200).json({
        status: true,
        data: adminNotifications,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public archiveGetAllCount = async (
    req: Request,
    res: Response<IResp<number>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const archiveNotificationsCount =
        await this.getArchiveNotificationsCount();

      res.status(200).json({
        status: true,
        data: archiveNotificationsCount,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public archiveGetAll = async (
    req: Request,
    res: Response<IResp<any>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const archiveNotifications = await this.getArchiveNotifications();

      res.status(200).json({
        status: true,
        data: archiveNotifications,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public settingsGetAllCount = async (
    req: Request,
    res: Response<IResp<number>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const settingsNotificationsCount =
        await this.getSettingsNotificationsCount();

      res.status(200).json({
        status: true,
        data: settingsNotificationsCount,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public settingsGetAll = async (
    req: Request,
    res: Response<IResp<any>>
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const settingsNotifications = await this.getSettingsNotifications();

      res.status(200).json({
        status: true,
        data: settingsNotifications,
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };

  public getAllCounts = async (
    req: Request,
    res: Response<
      IResp<{
        admin: number;
        archive: number;
        settings: number;
      }>
    >
  ): Promise<void> => {
    const { id, role } = req.body.user;

    try {
      const adminNotificationsCount = await this.getAdminNotificationsCount();
      const archiveNotificationsCount: number = 0;
      const settingsNotificationsCount: number = 0;

      res.status(200).json({
        status: true,
        data: {
          admin: adminNotificationsCount,
          archive: archiveNotificationsCount,
          settings: settingsNotificationsCount,
        },
      });
      return;
    } catch (err) {
      console.log(err);
      res.status(500).json({ status: false, error: errors.serverError });
      return;
    }
  };
}

export default new NotificationController();
